import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "ai-next-app",
  description: "Starter AI web app template.",
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
