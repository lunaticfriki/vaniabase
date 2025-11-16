import { useNavigate } from 'react-router-dom';

export const BackButtonComponent = () => {
  const navigate = useNavigate();

  return (
    <div className="flex justify-center">
      <button
        onClick={() => navigate(-1)}
        className="px-6 py-2 text-pink-500 border-2 border-pink-500 rounded hover:bg-pink-500 hover:text-white transition-colors cursor-pointer"
      >
        Back
      </button>
    </div>
  );
};
