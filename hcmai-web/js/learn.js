import { collection, addDoc, doc, getDocs, getFirestore, orderBy, query, updateDoc, where } from 'https://www.gstatic.com/firebasejs/12.2.1/firebase-firestore.js';
import { getBlob, getStorage, ref, uploadBytes } from 'https://www.gstatic.com/firebasejs/12.2.1/firebase-storage.js';
import { auth } from './auth.js';

const db = getFirestore();
const storage = getStorage();
const grid = document.getElementById('raagGrid');
const searchInput = document.getElementById('raagSearch');
const status = document.getElementById('raagStatus');

const fallbackRaags = [
  { name: 'Bhairav', description: 'Devotion and intimacy', timeOfDay: 'Morning', thaat: 'Bhairav', jati: 'Sampurna', prahar: 1 },
  { name: 'Yaman', description: 'Royal elegance', timeOfDay: 'Evening', thaat: 'Kalyan', jati: 'Sampurna', prahar: 5 },
  { name: 'Bageshree', description: 'Night bloom', timeOfDay: 'Night', thaat: 'Kafi', jati: 'Sampurna', prahar: 6 }
];

function escapeHtml(value = '') {
  return String(value).replace(/[&<>'"]/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[character]));
}

function renderRaags(raags) {
  if (!grid) return;
  grid.innerHTML = raags.map((raag) => `
    <article class="music-card raag-card" data-search="${escapeHtml(`${raag.name} ${raag.description} ${raag.thaat} ${raag.timeOfDay} ${raag.jati}`)}">
      <button class="card-open" type="button" data-raag-id="${escapeHtml(raag.id || '')}">
        <div class="card-badge accent">${escapeHtml(raag.name)}</div>
        <h3>${escapeHtml(raag.description || 'Raag study')}</h3>
        <p>${escapeHtml(raag.thaat || 'Classical repertoire')} · ${escapeHtml(raag.jati || 'Sampurna')}</p>
        <div class="meta-row"><span>${escapeHtml(raag.timeOfDay || 'Any time')}</span><span>${escapeHtml(`Prahar ${raag.prahar || '-'}`)}</span></div>
      </button>
    </article>
  `).join('');

  grid.querySelectorAll('[data-raag-id]').forEach((button) => {
    button.addEventListener('click', () => openRaagDetail(raags.find((raag) => raag.id === button.dataset.raagId)));
  });
}

function filterRaags() {
  const queryText = searchInput?.value.trim().toLowerCase() || '';
  grid?.querySelectorAll('.raag-card').forEach((card) => {
    card.hidden = queryText && !card.dataset.search.toLowerCase().includes(queryText);
  });
}

async function loadRaags() {
  if (!grid) return;
  status.textContent = 'Loading the live raag library...';
  try {
    const raagQuery = query(collection(db, 'raags'), where('isPublished', '==', true));
    const snapshot = await getDocs(raagQuery);
    const raags = snapshot.docs.map((document) => ({ id: document.id, ...document.data() }));
    renderRaags(raags.length ? raags : fallbackRaags);
    status.textContent = raags.length ? `${raags.length} raags in the library` : 'Showing starter raags until the library is published.';
  } catch (error) {
    renderRaags(fallbackRaags);
    status.textContent = 'Showing starter raags. Sign in and deploy Firebase rules to use the live library.';
    console.error('Unable to load raags.', error);
  }
}

function openRaagDetail(raag) {
  if (!raag) return;
  const modal = document.createElement('div');
  modal.className = 'auth-modal';
  modal.innerHTML = `<div class="auth-sheet raag-detail-sheet">
    <div class="auth-header"><div><p class="eyebrow">Raag study</p><h3>${escapeHtml(raag.name)}</h3></div><button class="close-auth" type="button">✕</button></div>
    <p class="raag-description">${escapeHtml(raag.description || 'Explore the melodic personality of this raag.')}</p>
    <div class="raag-facts"><span>${escapeHtml(raag.thaat || 'Thaat pending')}</span><span>${escapeHtml(raag.jati || 'Jati pending')}</span><span>${escapeHtml(raag.timeOfDay || 'Time pending')}</span></div>
    <div class="topic-list"><p class="eyebrow">Recordings and topics</p><p class="topic-status">Sign in to load protected recordings.</p></div>
  </div>`;
  document.body.appendChild(modal);
  modal.querySelector('.close-auth').addEventListener('click', () => modal.remove());
  loadTopics(raag, modal.querySelector('.topic-list'));
}

async function loadTopics(raag, target) {
  if (!raag.id || !target) return;
  if (!auth.currentUser) {
    target.querySelector('.topic-status').textContent = 'Log in to access recordings and protected topics.';
    return;
  }
  try {
    const topicQuery = query(collection(db, 'raags', raag.id, 'topics'), orderBy('orderIndex'));
    const snapshot = await getDocs(topicQuery);
    const isAdmin = (await auth.currentUser.getIdTokenResult()).claims.admin === true;
    target.innerHTML = `${isAdmin ? '<button class="secondary-btn small add-topic-button" type="button">+ Add recording</button>' : ''}${snapshot.empty ? '<p class="topic-status">No recordings uploaded yet.</p>' : snapshot.docs.map((document) => {
      const topic = { id: document.id, ...document.data() };
      return `<article class="topic-row"><div><strong>${escapeHtml(topic.title)}</strong><p>${escapeHtml(topic.text || '')}</p></div>${topic.audioPath ? `<button class="secondary-btn small topic-play" type="button" data-audio-path="${escapeHtml(topic.audioPath)}">Play</button>` : ''}</article>`;
    }).join('')}`;
    target.querySelectorAll('.topic-play').forEach((button) => button.addEventListener('click', () => playProtectedAudio(button)));
    target.querySelector('.add-topic-button')?.addEventListener('click', () => openAddTopic(raag, target));
  } catch (error) {
    target.querySelector('.topic-status').textContent = 'Topics could not be loaded.';
    console.error('Unable to load topics.', error);
  }
}

function openAddTopic(raag, target) {
  const modal = document.createElement('div');
  modal.className = 'auth-modal';
  modal.innerHTML = `<div class="auth-sheet"><div class="auth-header"><h3>Add Recording</h3><button class="close-auth" type="button">✕</button></div><form class="auth-form" id="add-topic-form"><label><span>Topic</span><select name="title"><option>Intro</option><option>Alankars</option><option>Palta</option><option>Sargam Geet</option><option>Bandish</option><option>Tarana</option></select></label><label><span>Text</span><textarea name="text" rows="4"></textarea></label><label><span>Audio MP3</span><input name="audio" type="file" accept="audio/mpeg" required></label><label><span>Order</span><input name="orderIndex" type="number" min="1" max="10" value="1" required></label><label class="check-row"><input name="requiresLogin" type="checkbox" checked> <span>Require login to play</span></label><button class="primary-btn" type="submit">Upload recording</button></form></div>`;
  document.body.appendChild(modal);
  modal.querySelector('.close-auth').addEventListener('click', () => modal.remove());
  modal.querySelector('form').addEventListener('submit', async (event) => {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const file = form.get('audio');
    if (!(file instanceof File) || file.type !== 'audio/mpeg') return;
    const topicRef = await addDoc(collection(db, 'raags', raag.id, 'topics'), { title: form.get('title'), text: form.get('text'), requiresLogin: form.get('requiresLogin') === 'on', orderIndex: Number(form.get('orderIndex')) });
    const audioPath = `audio/${topicRef.id}.mp3`;
    await uploadBytes(ref(storage, audioPath), file, { contentType: 'audio/mpeg' });
    await updateDoc(doc(db, 'raags', raag.id, 'topics', topicRef.id), { audioPath });
    modal.remove();
    loadTopics(raag, target);
  });
}

async function playProtectedAudio(button) {
  button.disabled = true;
  button.textContent = 'Loading...';
  try {
    const blob = await getBlob(ref(storage, button.dataset.audioPath));
    const audio = new Audio(URL.createObjectURL(blob));
    audio.play();
    button.textContent = 'Playing';
    audio.addEventListener('ended', () => { URL.revokeObjectURL(audio.src); button.textContent = 'Play'; button.disabled = false; });
  } catch (error) {
    button.textContent = 'Unavailable';
    console.error('Unable to play protected audio.', error);
  }
}

function openAddRaag() {
  const modal = document.createElement('div');
  modal.className = 'auth-modal';
  modal.innerHTML = `<div class="auth-sheet"><div class="auth-header"><h3>New Raag</h3><button class="close-auth" type="button">✕</button></div><form class="auth-form" id="add-raag-form"><label><span>Name</span><input name="name" required></label><label><span>Thaat</span><input name="thaat" required></label><label><span>Jati</span><input name="jati" value="Sampurna" required></label><label><span>Time of day</span><input name="timeOfDay" value="Morning" required></label><label><span>Prahar</span><input name="prahar" type="number" min="1" max="8" value="1" required></label><label><span>Description</span><textarea name="description" rows="4"></textarea></label><label class="check-row"><input name="isPublished" type="checkbox"> <span>Publish to directory</span></label><button class="primary-btn" type="submit">Save Raag</button></form></div>`;
  document.body.appendChild(modal);
  modal.querySelector('.close-auth').addEventListener('click', () => modal.remove());
  modal.querySelector('form').addEventListener('submit', async (event) => {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const data = { name: form.get('name'), thaat: form.get('thaat'), jati: form.get('jati'), timeOfDay: form.get('timeOfDay'), prahar: Number(form.get('prahar')), description: form.get('description'), isPublished: form.get('isPublished') === 'on' };
    try { await addDoc(collection(db, 'raags'), data); modal.remove(); loadRaags(); } catch (error) { alert('Firebase rejected this change. Check admin claims and deployed rules.'); console.error(error); }
  });
}

searchInput?.addEventListener('input', filterRaags);
document.querySelector('[data-admin-only]')?.addEventListener('click', openAddRaag);
loadRaags();