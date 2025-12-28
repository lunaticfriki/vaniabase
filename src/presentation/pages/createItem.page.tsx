import { useState } from 'preact/hooks';
import { route } from 'preact-router';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { NotificationService } from '../../domain/services/notification.service';
import { Item } from '../../domain/model/entities/item.entity';
import { Category } from '../../domain/model/entities/category.entity';
import { Id } from '../../domain/model/value-objects/id.valueObject';
import {
  Title,
  Description,
  Author,
  Cover,
  Owner,
  Topic,
  Format,
  Publisher,
  Language
} from '../../domain/model/value-objects/stringValues.valueObject';
import { Tags } from '../../domain/model/value-objects/tags.valueObject';
import { Created, Completed, Year } from '../../domain/model/value-objects/dateAndNumberValues.valueObject';
import { v4 as uuidv4 } from 'uuid';

const getRandomCover = () => {
  const width = 600;
  const height = 900;
  const id = Math.floor(Math.random() * 1000);
  return `https://picsum.photos/id/${id}/${width}/${height}`;
};

export function CreateItem() {
  const itemStateService = container.get(ItemStateService);
  const notificationService = container.get(NotificationService);

  const [formData, setFormData] = useState({
    title: '',
    description: '',
    author: '',
    cover: getRandomCover(),
    owner: '',
    tags: '',
    topic: '',
    format: '',
    created: new Date().toISOString().split('T')[0],
    completed: '',
    year: new Date().getFullYear().toString(),
    publisher: '',
    language: 'English',
    category: 'books'
  });

  const handleInput = (e: Event) => {
    const target = e.target as HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement;
    setFormData(prev => ({ ...prev, [target.name]: target.value }));
  };

  const handleSubmit = async (e: Event) => {
    e.preventDefault();

    try {
      const tagsArray = formData.tags
        .split(',')
        .map(t => t.trim())
        .filter(Boolean);

      await itemStateService.createItem(
        Item.create(
          Id.create(uuidv4()),
          Title.create(formData.title),
          Description.create(formData.description),
          Author.create(formData.author),
          Cover.create(formData.cover),
          Owner.create(formData.owner),
          Tags.create(tagsArray),
          Topic.create(formData.topic),
          Format.create(formData.format),
          Created.create(new Date(formData.created)),
          formData.completed ? Completed.create(new Date(formData.completed)) : Completed.empty(),
          Year.create(parseInt(formData.year) || 0),
          Publisher.create(formData.publisher),
          Language.create(formData.language),
          Category.create(Id.create(uuidv4()), Title.create(formData.category)),
          Id.empty()
        )
      );

      notificationService.success('Item created successfully!');
      route('/');
    } catch (error) {
      notificationService.error('Failed to create item');
      console.error(error);
    }
  };

  return (
    <div class="max-w-2xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-12">
      <div class="space-y-2">
        <h1 class="text-4xl md:text-5xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          CREATE NEW ITEM
        </h1>
        <p class="text-white/60">Add a new entry to the timeline collection.</p>
      </div>

      <form onSubmit={handleSubmit} class="space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div class="space-y-2">
            <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">Title</label>
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
            <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">Author</label>
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
          <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">Description</label>
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
            <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">Category</label>
            <select
              name="category"
              value={formData.category}
              onChange={handleInput}
              class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors appearance-none"
            >
              <option value="books">Books</option>
              <option value="movies">Movies</option>
              <option value="games">Games</option>
              <option value="music">Music</option>
            </select>
          </div>

          <div class="space-y-2">
            <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">Year</label>
            <input
              type="number"
              name="year"
              value={formData.year}
              onInput={handleInput}
              class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors"
            />
          </div>

          <div class="space-y-2">
            <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">Format</label>
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
            <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">Publisher</label>
            <input
              type="text"
              name="publisher"
              value={formData.publisher}
              onInput={handleInput}
              class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors"
            />
          </div>
          <div class="space-y-2">
            <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">Language</label>
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
            <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">Owner</label>
            <input
              type="text"
              name="owner"
              value={formData.owner}
              onInput={handleInput}
              class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors"
            />
          </div>
          <div class="space-y-2">
            <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">Topic</label>
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
          <label class="text-xs font-bold uppercase tracking-widest text-brand-magenta">Tags (comma separated)</label>
          <input
            type="text"
            name="tags"
            value={formData.tags}
            onInput={handleInput}
            placeholder="scifi, classic, bestseller"
            class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors"
          />
        </div>

        <div class="space-y-2">
          <label class="text-xs font-bold uppercase tracking-widest text-white/40">Cover Image (Auto-generated)</label>
          <input
            type="text"
            name="cover"
            value={formData.cover}
            disabled
            class="w-full bg-zinc-900/50 border border-white/5 rounded p-3 text-white/50 cursor-not-allowed"
          />
          <p class="text-xs text-white/30">A random image will be assigned on creation.</p>
        </div>

        <div class="pt-4">
          <button
            type="submit"
            class="w-full bg-brand-magenta text-white font-bold uppercase tracking-widest py-4 rounded hover:bg-brand-magenta/80 transition-all hover:scale-[1.01] active:scale-[0.99] shadow-lg shadow-brand-magenta/20"
          >
            Create Item
          </button>
        </div>
      </form>
    </div>
  );
}
