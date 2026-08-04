import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Reliability Atlas",
  description: "The DevOps, SRE & Platform Engineering Field Manual — an Ubuntu-first guide to production systems and judgment.",
  icons: {
    icon: "/favicon.svg",
    shortcut: "/favicon.svg",
  },
};

const restoreReaderPreferences = `(function(){try{var r=document.documentElement,s=localStorage;var pairs=[['readerTheme','field-manual-theme',['paper','night','sepia'],'paper'],['readingSize','field-manual-reading-size',['compact','comfortable','large'],'comfortable'],['readingLeading','field-manual-reading-leading',['tight','relaxed','airy'],'relaxed'],['readingWidth','field-manual-reading-width',['narrow','standard','wide'],'standard'],['codeWrap','field-manual-code-wrap',['wrap','scroll'],'scroll'],['readingFocus','field-manual-reading-focus',['on','off'],'off'],['navigation','field-manual-navigation',['open','closed'],'open'],['contextRail','field-manual-context-rail',['open','closed'],'open']];pairs.forEach(function(p){var v=s.getItem(p[1]);r.dataset[p[0]]=p[2].indexOf(v)>-1?v:p[3]});if(innerWidth<=980&&!s.getItem('field-manual-navigation'))r.dataset.navigation='closed';if(innerWidth<=1180&&!s.getItem('field-manual-context-rail'))r.dataset.contextRail='closed'}catch(e){}})();`;

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
      </body>
    </html>
  );
}
