import type { Metadata } from "next";
import "./globals.css";
import ReaderControls from "./reader-controls";

export const metadata: Metadata = {
  title: "Reliability Atlas",
  description: "The DevOps, SRE & Platform Engineering Field Manual — an Ubuntu-first guide to production systems and judgment.",
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
        <a className="skip-link" href="#main-content">Skip to main content</a>
        {children}
        <ReaderControls />
      </body>
    </html>
  );
}
