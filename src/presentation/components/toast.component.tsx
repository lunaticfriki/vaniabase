import { useEffect, useState } from 'preact/hooks';
import type { Notification } from '../../domain/services/notification.service';

interface Props {
  notification: Notification;
  onClose: (id: string) => void;
}

export function Toast({ notification, onClose }: Props) {
  const [isClosing, setIsClosing] = useState(false);

  const handleClose = () => {
    setIsClosing(true);
    setTimeout(() => {
      onClose(notification.id);
    }, 300);
  };

  useEffect(() => {
    if (notification.duration && notification.duration > 0) {
      const timer = setTimeout(handleClose, notification.duration);
      return () => clearTimeout(timer);
    }
  }, [notification]);

  return (
    <div
      class={`
        flex items-center gap-3 p-4 
        bg-zinc-900 border border-brand-magenta rounded-sm shadow-lg
        transform transition-all duration-300 ease-in-out
        ${isClosing ? 'opacity-0 translate-x-full' : 'opacity-100 translate-x-0'}
        animate-in slide-in-from-right-full fade-in
      `}
      role="alert"
    >
      <div class="flex-1">
        <p class="text-sm font-medium text-brand-magenta uppercase tracking-wider">{notification.type}</p>
        <p class="text-white/90 text-sm mt-1">{notification.message}</p>
      </div>
      <button
        onClick={handleClose}
        class="text-white/40 hover:text-white transition-colors"
        aria-label="Close notification"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
  );
}
