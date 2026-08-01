import type { Metadata } from "next";
import "./globals.css";
import ReaderControls from "./reader-controls";

export const metadata: Metadata = {
  title: "Systems Reliability Field Manual",
  description: "An Ubuntu-first field manual for DevOps, SRE, platform, data, and production engineering.",
  icons: {
    icon: "/favicon.svg",
    shortcut: "/favicon.svg",
  },
};

const restoreReaderPreferences = `(function(){try{var r=document.documentElement;var t=localStorage.getItem('field-manual-theme');var s=localStorage.getItem('field-manual-reading-size');if(t==='paper'||t==='night')r.dataset.readerTheme=t;if(s==='compact'||s==='comfortable'||s==='large')r.dataset.readingSize=s}catch(e){}})();`;

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: restoreReaderPreferences }} />
      </head>
      <body>
        <a className="skip-link" href="#main-content">Skip to the lesson</a>
        {children}
        <ReaderControls />
      </body>
    </html>
  );
}
