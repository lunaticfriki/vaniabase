export const FooterComponent = () => {
  return (
    <footer className="p-4">
      <p>
        @lunaticfriki,
        <span className="text-pink-500">{new Date().getFullYear()}</span>
      </p>
    </footer>
  );
};
