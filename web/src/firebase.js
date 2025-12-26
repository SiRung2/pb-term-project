import { initializeApp } from "firebase/app";
import { getAuth, GoogleAuthProvider } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
    apiKey: "AIzaSyDYQRflsQHrFZ3i60fe4a05PRW3F2RKWfQ",
    authDomain: "my-pb-tp.firebaseapp.com",
    projectId: "my-pb-tp",
    storageBucket: "my-pb-tp.firebasestorage.app",
    messagingSenderId: "709231411062",
    appId: "1:709231411062:web:95bb71a4207dd35b52c457",
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const provider = new GoogleAuthProvider();
export const db = getFirestore(app);
