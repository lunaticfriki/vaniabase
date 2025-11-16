import { useNavigate } from 'react-router-dom';

export const BackButtonComponent = () => {
  const navigate = useNavigate();

  return (
    <div className="flex justify-center">
      <button
        onClick={() => navigate(-1)}
        data-text="Back"
        className="cyber-button text-pink-500 hover:text-white"
      >
        Back
      </button>
    </div>
  );
};
