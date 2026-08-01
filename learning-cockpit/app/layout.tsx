import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "DevOps/SRE Learning Cockpit",
  description: "Abhishek's local visual practice system for DevOps and SRE mastery.",
  icons: {
    icon: "/favicon.svg",
    shortcut: "/favicon.svg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
