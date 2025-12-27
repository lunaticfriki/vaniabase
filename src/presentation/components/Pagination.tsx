import { PaginationViewModel } from '../viewModels/PaginationViewModel';

interface PaginationProps {
  pagination: PaginationViewModel;
}

export function Pagination({ pagination }: PaginationProps) {
  const currentPage = pagination.currentPage.value;
  const totalPages = pagination.totalPages.value;

  if (totalPages <= 1) return null;

  return (
    <div class="flex justify-center items-center gap-4 mt-8">
      <button
        class="px-4 py-2 bg-white/5 border border-white/10 rounded hover:bg-brand-magenta hover:text-white transition-colors disabled:opacity-50 disabled:hover:bg-white/5 disabled:cursor-not-allowed"
        onClick={() => pagination.prevPage()}
        disabled={currentPage === 1}
      >
        Previous
      </button>

      <span class="text-white/60">
        Page <span class="text-white font-bold">{currentPage}</span> of {totalPages}
      </span>

      <button
        class="px-4 py-2 bg-white/5 border border-white/10 rounded hover:bg-brand-magenta hover:text-white transition-colors disabled:opacity-50 disabled:hover:bg-white/5 disabled:cursor-not-allowed"
        onClick={() => pagination.nextPage()}
        disabled={currentPage === totalPages}
      >
        Next
      </button>
    </div>
  );
}
