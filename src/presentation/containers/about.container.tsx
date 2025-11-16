export const AboutContainer = () => {
  return (
    <>
      <p className="text-lg">Welcome to Vaniabase</p>
      <p>Version: 1.0.0</p>
      <p>
        by @lunaticfriki,
        <span className="text-pink-500"> {new Date().getFullYear()}</span>
      </p>
    </>
  );
};
