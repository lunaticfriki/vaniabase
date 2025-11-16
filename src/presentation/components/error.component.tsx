interface ErrorComponentProps {
  error?: string;
}

export const ErrorComponent = ({ error = 'Error' }: ErrorComponentProps) => {
  return (
    <div className="flex items-center justify-center w-full min-h-[200px] p-4">
      <div className="cyber-error max-w-2xl w-full">
        <div className="cyber-error-header">
          <span className="cyber-error-icon">⚠</span>
          <h3 className="cyber-error-title">{error}</h3>
        </div>
      </div>
    </div>
  );
};
