import type { ComponentChildren } from 'preact';
import { Header } from './Header';
import { Footer } from './Footer';
import { ToastContainer } from './ToastContainer';

interface LayoutProps {
  children: ComponentChildren;
}

export function Layout({ children }: LayoutProps) {
  return (
    <div class="min-h-screen bg-[#242424] text-white font-sans flex flex-col">
      <Header />

      <main class="grow pt-24 pb-12 px-4 container mx-auto">{children}</main>

      <Footer />
      <ToastContainer />
    </div>
  );
}
