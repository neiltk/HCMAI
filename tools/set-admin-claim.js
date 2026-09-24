const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

const projectId = 'hcmai-v3e0h9';
const adminUserUid = '09JvBvWi5rebnT4honz5Q2N6Uoe2';

initializeApp({
  credential: applicationDefault(),
  projectId
});

getAuth().setCustomUserClaims(adminUserUid, { admin: true })
  .then(() => {
    console.log(`Admin claim granted to ${adminUserUid}.`);
    console.log('Sign out and sign back in to refresh the Firebase ID token.');
  })
  .catch((error) => {
    console.error('Unable to grant admin claim:', error.message);
    process.exitCode = 1;
  });