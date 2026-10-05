import { useEffect, useState } from "react";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import "./App.css";

const docs = import.meta.glob("../../docs/*.md", {
  query: "?raw",
  import: "default",
}) as Record<string, () => Promise<string>>;

type DocEntry = { key: string; name: string; title: string };

function entryFromKey(key: string): DocEntry {
  const name = key.split("/").pop()!.replace(/\.md$/, "");
  return { key, name, title: name.replace(/([a-z])([A-Z])/g, "$1 $2") };
}

const entries: DocEntry[] = Object.keys(docs)
  .map(entryFromKey)
  .sort((a, b) => a.name.localeCompare(b.name));

export default function App() {
  const [active, setActive] = useState<DocEntry>(entries[0]);
  const [content, setContent] = useState<string>("");

  useEffect(() => {
    let cancelled = false;
    docs[active.key]().then((text) => {
      if (!cancelled) setContent(text);
    });
    return () => {
      cancelled = true;
    };
  }, [active]);

  return (
    <div className="layout">
      <aside className="sidebar">
        <h1 className="brand">opencode-workflow-demo</h1>
        <nav>
          {entries.map((e) => (
            <button
              key={e.key}
              className={e.key === active.key ? "nav-item active" : "nav-item"}
              onClick={() => setActive(e)}
            >
              {e.title}
            </button>
          ))}
        </nav>
      </aside>
      <main className="content">
        <ReactMarkdown remarkPlugins={[remarkGfm]}>{content}</ReactMarkdown>
      </main>
      <aside className="toc">{/* placeholder for future right-rail TOC */}</aside>
    </div>
  );
}
