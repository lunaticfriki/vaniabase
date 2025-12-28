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
        transform transition-all duration-300 ease-in-out
        ${isClosing ? 'opacity-0 translate-x-full' : 'opacity-100 translate-x-0'}
        animate-in slide-in-from-right-full fade-in
      `}
      style="filter: drop-shadow(4px 4px 0px rgba(255, 0, 255, 0.5));"
      role="alert"
    >
      <div
        class="flex items-center gap-3 p-4 bg-zinc-900 border-l-2 border-brand-magenta"
        style="clip-path: polygon(10px 0, 100% 0, 100% calc(100% - 10px), calc(100% - 10px) 100%, 0 100%, 0 10px);"
      >
        <div class="flex-1">
          <p class="text-xs font-bold text-brand-magenta uppercase tracking-widest">{notification.type}</p>
          <p class="text-white/90 text-sm mt-1 font-medium">{notification.message}</p>
        </div>
        <button
          onClick={handleClose}
          class="text-white/40 hover:text-white transition-colors p-1"
          aria-label="Close notification"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    </div>
  );
}
