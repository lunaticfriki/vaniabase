export const FooterComponent = () => {
  return (
    <footer className="p-4">
      <a
        href="https://github.com/lunaticfriki"
        target="_blank"
        rel="noopener noreferrer"
        className="text-white"
      >
        @lunaticfriki,
        <span className="text-pink-500">{new Date().getFullYear()}</span>
      </a>
    </footer>
  );
};
