const admin = require('firebase-admin');

const projectId = 'hcmai-v3e0h9';
const adminUserUid = '09JvBvWi5rebnT4honz5Q2N6Uoe2';

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId
});

admin.auth().setCustomUserClaims(adminUserUid, { admin: true })
  .then(() => {
    console.log(`Admin claim granted to ${adminUserUid}.`);
    console.log('Sign out and sign back in to refresh the Firebase ID token.');
  })
  .catch((error) => {
    console.error('Unable to grant admin claim:', error.message);
    process.exitCode = 1;
  });