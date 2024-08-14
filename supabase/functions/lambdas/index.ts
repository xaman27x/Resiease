// deno-lint-ignore-file
import { initializeApp } from 'https://www.gstatic.com/firebasejs/9.8.0/firebase-app.js';
import { getFirestore, collection, onSnapshot, updateDoc, doc } from 'https://www.gstatic.com/firebasejs/9.8.0/firebase-firestore.js';
import { corsHeaders } from './cors.ts';

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

const apiKey = env.GOOGLE_API_KEY;

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function generateContent(text: string): Promise<string> {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              {
                text: 'Return the Severity of The Following Issue in a Housing Complex as a Single Digit Integer on a Scale of 1-5, with 1 being the lowest and 5 being the highest: ' + text + ' It is Important to return the output as a Single Int ONLY!',
              },
            ],
          },
        ],
      }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    const generatedText = data.candidates[0].content.parts[0].text.trim();
    return generatedText;
  } catch (error) {
    console.error('Error generating content:', error);
    throw error;
  }
}

async function generateContent_Alert(text: string): Promise<string> {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.0-pro:generateContent?key=${apiKey}`;

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              {
                text: 'Return the Severity of The Following Alert Given By Admin To All Residents in a Housing Complex as a Single Digit Integer on a Scale of 1-5, with 1 being the lowest and 5 being the highest: ' + text + ' It is Important to return the output as a Single Int ONLY!',
              },
            ],
          },
        ],
      }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    const generatedText = data.candidates[0].content.parts[0].text.trim();
    return generatedText;
  } catch (error) {
    console.error('Error generating content:', error);
    throw error;
  }
}

async function processNewComplaint(documentSnapshot: any) {
  const data = documentSnapshot.data();
  const complaintText = data['Complaint'];

  try {
    const response_severity = await generateContent(complaintText);
    await updateDoc(doc(db, 'ResidencyComplaints', documentSnapshot.id), {
      Severity: response_severity,
    });

    console.log('Severity successfully written to Firestore.');
  } catch (error) {
    console.error('Error processing complaint:', error);
  }
}

async function processNewAlert(documentSnapshot: any) {
  const data = documentSnapshot.data();
  const alertText = data['Alert'];

  try {
    const alert_severity = await generateContent_Alert(alertText);
    await updateDoc(doc(db, 'ResidencyAlerts', documentSnapshot.id), {
      Severity: alert_severity,
    });

    console.log('Severity successfully written to Firestore.');
  } catch (error) {
    console.error('Error processing alert:', error);
  }
}

Deno.serve(async (req) => {
  const Complaintquery = collection(db, 'ResidencyComplaints');
  onSnapshot(Complaintquery, (snapshot: { docChanges: () => any[]; }) => {
    snapshot.docChanges().forEach((change) => {
      if (change.type === 'added') {
        processNewComplaint(change.doc);
      }
    });
  });


  const Alertquery = collection(db, 'ResidencyAlerts');
  onSnapshot(Alertquery, (snapshot: { docChanges: () => any[]; }) => {
    snapshot.docChanges().forEach((change) => {
      if (change.type === 'added') {
        processNewAlert(change.doc);
      }
    });
  });
  if(req.method == 'POST' || req.method == 'PUT' || req.method == 'GET') {
    Headers: corsHeaders;
  }
  return new Response('Listening for new ResidencyComplaints...\n\n', { status: 200 });
});
