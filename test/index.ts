/**import { initializeApp } from 'https://www.gstatic.com/firebasejs/9.8.0/firebase-app.js';
import { getFirestore, collection, onSnapshot, updateDoc, doc } from 'https://www.gstatic.com/firebasejs/9.8.0/firebase-firestore.js';
import { generateContent } from './index.js';
import { GoogleGenerativeAI } from 'https://cdn.skypack.dev/@google/generative-ai';

// Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyBdSVt9Yr6RdT8qWHzAh05vVXBARvYjKbg",
  authDomain: "resiease.firebaseapp.com",
  databaseURL: "https://resiease-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "resiease",
  storageBucket: "resiease.appspot.com",
  messagingSenderId: "388643545730",
  appId: "1:388643545730:web:27c5cbf0c3592ee08d0a9b",
  measurementId: "G-GCK7YVD96H"
};
let globalError = '';
// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function processNewComplaint(documentSnapshot: any) {
  const data = documentSnapshot.data();
  const complaintText = data['Complaint'];

  try {
    const severity = await generateContent(complaintText);
    // deno-lint-ignore valid-typeof
    if(severity) {
      await updateDoc(doc(db, 'ResidencyComplaints', documentSnapshot.id), {
        Severity: '3',
      });
    } else {
    await updateDoc(doc(db, 'ResidencyComplaints', documentSnapshot.id), {
      Severity: severity,
    });
  }

    console.log('Severity successfully written to Firestore.');
  } catch (error) {
    globalError = error;
    (error);
    console.error('Error processing complaint:', error);
    return new Response(error, {status: 200});
  }
}

Deno.serve(async () => {
  const query = collection(db, 'ResidencyComplaints');
  onSnapshot(query, (snapshot: { docChanges: () => any[]; }) => {
    snapshot.docChanges().forEach((change) => {
      if (change.type === 'added') {
        processNewComplaint(change.doc);
      }
    });
  });

  return new Response('Listening for new ResidencyComplaints...\n\n' + globalError, { status: 200 })
  
});
**/