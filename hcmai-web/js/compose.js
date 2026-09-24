const output = document.getElementById('notationOutput');
const title = document.getElementById('notationTitle');
let notation = '';

function renderNotation() { output.textContent = notation || 'Tap a Swara to start...'; }

const swaras = ['S', 'R', 'G', 'M', 'P', 'D', 'N', '-'];
const grid = document.getElementById('swaraGrid');
swaras.forEach((swara) => {
  const button = document.createElement('button');
  button.textContent = swara;
  button.addEventListener('click', () => {
    if (swara === '-') notation += '- ';
    else {
      const pitch = document.getElementById('pitch').value;
      const octave = document.getElementById('octave').value;
      notation += swara + (pitch === 'komal' ? '\u0331' : pitch === 'tivra' ? "'" : '') + (octave === 'lower' ? '\u0323' : octave === 'upper' ? '\u0307' : '') + ' ';
    }
    renderNotation();
  });
  grid.appendChild(button);
});

document.querySelectorAll('[data-token]').forEach((button) => button.addEventListener('click', () => { notation += `${button.dataset.token} `; renderNotation(); }));
document.getElementById('deleteNotation').addEventListener('click', () => { notation = notation.trimEnd().slice(0, -1).trimEnd() + (notation ? ' ' : ''); renderNotation(); });
document.getElementById('clearNotation').addEventListener('click', () => { notation = ''; title.value = ''; renderNotation(); });
document.getElementById('printNotation').addEventListener('click', () => window.print());