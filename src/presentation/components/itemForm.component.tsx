import { useState, useEffect } from 'preact/hooks';
import { useTranslation } from 'react-i18next';
import { Item } from '../../domain/model/entities/item.entity';

export interface ItemFormData {
  title: string;
  description: string;
  author: string;
  cover: string;
  tags: string;
  topic: string;
  format: string;
  created: string;
  completed: boolean;
  year: string;
  publisher: string;
  language: string;
  category: string;
}

interface Props {
  initialValues: ItemFormData;
  onSubmit: (data: ItemFormData) => void;
  submitLabel: string;
  onUploadCover?: (file: File) => Promise<string>;
}

export function ItemForm({ initialValues, onSubmit, submitLabel, onUploadCover }: Props) {
  const { t } = useTranslation();
  const [formData, setFormData] = useState<ItemFormData>(initialValues);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    setFormData(initialValues);
  }, [initialValues]);

  const handleInput = (e: Event) => {
    const target = e.target as HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement;
    setFormData(prev => ({ ...prev, [target.name]: target.value }));
  };

  const handleUpload = async (e: Event) => {
    const target = e.target as HTMLInputElement;
    const file = target.files?.[0];
    if (file && onUploadCover) {
      try {
        setUploading(true);
        const url = await onUploadCover(file);
        setFormData(prev => ({ ...prev, cover: url }));
      } catch (error) {
        console.error('Failed to upload cover', error);
      } finally {
        setUploading(false);
      }
    }
  };

  const handleSubmit = (e: Event) => {
    e.preventDefault();
    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit} class="space-y-6">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="space-y-2">
          <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">
            {t('create_item.labels.title')}
          </label>
          <input
            type="text"
            name="title"
            value={formData.title}
            onInput={handleInput}
            class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors"
            required
          />
        </div>
        <div class="space-y-2">
          <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">
            {t('create_item.labels.author')}
          </label>
          <input
            type="text"
            name="author"
            value={formData.author}
            onInput={handleInput}
            class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors"
            required
          />
        </div>
      </div>
      <div class="space-y-2">
        <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">
          {t('create_item.labels.description')}
        </label>
        <textarea
          name="description"
          value={formData.description}
          onInput={handleInput}
          rows={4}
          class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors"
          required
        />
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="space-y-2">
          <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">
            {t('create_item.labels.category')}
          </label>
          <select
            name="category"
            value={formData.category}
            onChange={handleInput}
            class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors scheme-dark"
          >
            <option value="books">{t('categories.list.books')}</option>
            <option value="movies">{t('categories.list.movies')}</option>
            <option value="videogames">{t('categories.list.videogames')}</option>
            <option value="music">{t('categories.list.music')}</option>
            <option value="comics">{t('categories.list.comics')}</option>
            <option value="magazines">{t('categories.list.magazines')}</option>
          </select>
        </div>
        <div class="space-y-2">
          <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">
            {t('create_item.labels.year')}
          </label>
          <input
            type="number"
            name="year"
            value={formData.year}
            onInput={handleInput}
            class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors"
          />
        </div>
        <div class="space-y-2">
          <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">
            {t('create_item.labels.format')}
          </label>
          <input
            type="text"
            name="format"
            value={formData.format}
            onInput={handleInput}
            class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors"
          />
        </div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="space-y-2">
          <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">
            {t('create_item.labels.publisher')}
          </label>
          <input
            type="text"
            name="publisher"
            value={formData.publisher}
            onInput={handleInput}
            class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors"
          />
        </div>
        <div class="space-y-2">
          <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">
            {t('create_item.labels.language')}
          </label>
          <input
            type="text"
            name="language"
            value={formData.language}
            onInput={handleInput}
            class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors"
          />
        </div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="space-y-2">
          <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">
            {t('create_item.labels.tags')}
          </label>
          <input
            type="text"
            name="tags"
            value={formData.tags}
            onInput={handleInput}
            placeholder={t('create_item.placeholders.tags')}
            class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors"
          />
        </div>
        <div class="space-y-2">
          <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">
            {t('create_item.labels.topic')}
          </label>
          <input
            type="text"
            name="topic"
            value={formData.topic}
            onInput={handleInput}
            class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors"
          />
        </div>
      </div>
      <div class="space-y-2">
        <label class="text-xs font-bold uppercase tracking-widest text-white/40">{t('create_item.labels.cover')}</label>
        <div class="flex gap-4 items-center">
          <div class="flex-1">
            <input
              type="file"
              accept="image/*"
              onChange={handleUpload}
              disabled={uploading || !onUploadCover}
              class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-brand-magenta file:text-white hover:file:bg-brand-magenta/80"
            />
            {uploading && <p class="text-xs text-brand-magenta mt-1">Uploading...</p>}
          </div>
          <div class="w-16 h-16 shrink-0 bg-zinc-900 rounded overflow-hidden relative">
            <img src={formData.cover} alt="Cover preview" class="w-full h-full object-cover" />
          </div>
        </div>
        <p class="text-xs text-white/30">{t('create_item.auto_cover_info')}</p>
      </div>
      <div class="space-y-2 pt-6">
        <button
          type="button"
          onClick={() => {
            setFormData(prev => ({
              ...prev,
              completed: !prev.completed
            }));
          }}
          style="clip-path: polygon(10px 0, 100% 0, 100% calc(100% - 10px), calc(100% - 10px) 100%, 0 100%, 0 10px);"
          class={`
            w-full md:w-auto px-6 py-3 font-bold uppercase tracking-widest transition-all text-sm
            ${
              formData.completed
                ? 'bg-white/10 text-white/60 hover:bg-white/20 hover:text-white'
                : 'bg-green-500 text-black hover:bg-green-400 hover:scale-[1.02] shadow-[0_0_15px_rgba(34,197,94,0.3)]'
            }
              `}
        >
          {formData.completed ? t('create_item.buttons.mark_uncompleted') : t('create_item.buttons.mark_completed')}
        </button>
      </div>
      <div class="pt-4">
        <button
          type="submit"
          disabled={!Item.isEditable(initialValues, formData)}
          class={`
            w-full font-bold uppercase tracking-widest py-4 rounded transition-all
            ${
              !Item.isEditable(initialValues, formData)
                ? 'bg-zinc-800 text-white/30 cursor-not-allowed'
                : 'bg-brand-magenta text-white hover:bg-brand-magenta/80 hover:scale-[1.01] active:scale-[0.99] shadow-lg shadow-brand-magenta/20'
            }
          `}
        >
          {submitLabel}
        </button>
      </div>
    </form>
  );
}
