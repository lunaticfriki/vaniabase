import { useState, useEffect, useRef } from 'preact/hooks';
import { useTranslation } from 'react-i18next';
import { PaginationViewModel } from '../viewModels/pagination.viewModel';

interface PaginationProps {
  pagination: PaginationViewModel;
}

export function Pagination({ pagination }: PaginationProps) {
  const { t } = useTranslation();
  const currentPage = pagination.currentPage.value;
  const totalPages = pagination.totalPages.value;

  const [isEditing, setIsEditing] = useState(false);
  const [inputValue, setInputValue] = useState(currentPage.toString());
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    setInputValue(currentPage.toString());
  }, [currentPage]);

  useEffect(() => {
    if (isEditing && inputRef.current) {
      inputRef.current.focus();
      inputRef.current.select();
    }
  }, [isEditing]);

  const handleSubmit = () => {
    setIsEditing(false);
    const newPage = parseInt(inputValue, 10);
    if (!isNaN(newPage) && newPage >= 1 && newPage <= totalPages) {
      pagination.goToPage(newPage);
    } else {
      setInputValue(currentPage.toString());
    }
  };

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleSubmit();
    } else if (e.key === 'Escape') {
      setIsEditing(false);
      setInputValue(currentPage.toString());
    }
  };

  if (totalPages <= 1) return null;

  return (
    <div class="flex justify-center items-center gap-4 mt-8">
      <button
        class="px-4 py-2 bg-white/5 border border-white/10 rounded hover:bg-brand-magenta hover:text-white transition-colors disabled:opacity-50 disabled:hover:bg-white/5 disabled:cursor-not-allowed"
        onClick={() => pagination.prevPage()}
        disabled={currentPage === 1}
      >
        {t('pagination.previous')}
      </button>

      <span class="text-white/60 flex items-baseline gap-1">
        {t('pagination.page')}
        {isEditing ? (
          <input
            ref={inputRef}
            type="number"
            class="w-16 bg-white/10 border border-brand-magenta rounded text-white text-center font-bold px-1 py-0.5 focus:outline-none focus:ring-1 focus:ring-brand-magenta"
            value={inputValue}
            onInput={e => setInputValue(e.currentTarget.value)}
            onBlur={handleSubmit}
            onKeyDown={handleKeyDown}
            min={1}
            max={totalPages}
          />
        ) : (
          <span
            class="text-white font-bold cursor-pointer hover:text-brand-magenta transition-colors px-2"
            onClick={() => setIsEditing(true)}
            title={t('pagination.jump_to_page')}
          >
            {currentPage}
          </span>
        )}
        {t('pagination.of')} {totalPages}
      </span>

      <button
        class="px-4 py-2 bg-white/5 border border-white/10 rounded hover:bg-brand-magenta hover:text-white transition-colors disabled:opacity-50 disabled:hover:bg-white/5 disabled:cursor-not-allowed"
        onClick={() => pagination.nextPage()}
        disabled={currentPage === totalPages}
      >
        {t('pagination.next')}
      </button>
    </div>
  );
}
