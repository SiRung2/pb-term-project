import { useEffect, useMemo, useState } from "react";
import { signInWithPopup, signOut, onAuthStateChanged } from "firebase/auth";
import {
    collection,
    addDoc,
    deleteDoc,
    doc,
    onSnapshot,
    orderBy,
    query,
    updateDoc,
    serverTimestamp,
    where,
} from "firebase/firestore";
import { auth, provider, db } from "./firebase";

export default function App() {
    const [user, setUser] = useState(null);
    const [text, setText] = useState("");
    const [todos, setTodos] = useState([]);

    useEffect(() => {
        const unsub = onAuthStateChanged(auth, (u) => setUser(u));
        return () => unsub();
    }, []);

    const qRef = useMemo(() => {
        if (!user) return null;
        return query(
            collection(db, "todos"),
            where("ownerUid", "==", user.uid),
            orderBy("createdAt", "desc")
        );
    }, [user]);

    useEffect(() => {
        if (!qRef) return;
        const unsub = onSnapshot(qRef, (snap) => {
            setTodos(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
        });
        return () => unsub();
    }, [qRef]);

    const login = async () => {
        await signInWithPopup(auth, provider);
    };

    const logout = async () => {
        await signOut(auth);
    };

    const addTodo = async () => {
        if (!user) return;
        const v = text.trim();
        if (!v) return;

        await addDoc(collection(db, "todos"), {
            text: v,
            done: false,
            createdAt: serverTimestamp(),
            ownerUid: user.uid,
        });
        setText("");
    };

    const toggleDone = async (id, done) => {
        await updateDoc(doc(db, "todos", id), { done: !done });
    };

    const removeTodo = async (id) => {
        await deleteDoc(doc(db, "todos", id));
    };

    return (
        <div style={{ maxWidth: 520, margin: "40px auto", fontFamily: "sans-serif" }}>
            <h2>To-Do</h2>

            {!user ? (
                <button onClick={login}>Google 로그인</button>
            ) : (
                <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                    <div>{user.displayName}</div>
                    <button onClick={logout}>로그아웃</button>
                </div>
            )}

            {user && (
                <>
                    <div style={{ display: "flex", gap: 8, marginTop: 16 }}>
                        <input
                            value={text}
                            onChange={(e) => setText(e.target.value)}
                            placeholder="할 일을 입력"
                            style={{ flex: 1, padding: 8 }}
                        />
                        <button onClick={addTodo}>추가</button>
                    </div>

                    <ul style={{ marginTop: 16, paddingLeft: 18 }}>
                        {todos.map((t) => (
                            <li key={t.id} style={{ marginBottom: 8 }}>
                                <label style={{ cursor: "pointer" }}>
                                    <input
                                        type="checkbox"
                                        checked={!!t.done}
                                        onChange={() => toggleDone(t.id, t.done)}
                                    />{" "}
                                    <span style={{ textDecoration: t.done ? "line-through" : "none" }}>
                    {t.text}
                  </span>
                                </label>
                                <button onClick={() => removeTodo(t.id)} style={{ marginLeft: 10 }}>
                                    삭제
                                </button>
                            </li>
                        ))}
                    </ul>
                </>
            )}
        </div>
    );
}
