import { useState } from 'preact/hooks';
import { read, utils } from 'xlsx';
import { route } from 'preact-router';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { AuthService } from '../../application/auth/auth.service';
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
  const authService = container.get(AuthService);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    author: '',
    cover: getRandomCover(),
    tags: '',
    topic: '',
    format: '',
    created: new Date().toISOString().split('T')[0],
    completed: false, // Initialized as boolean
    year: new Date().getFullYear().toString(),
    publisher: '',
    language: 'English',
    category: 'books'
  });
  const handleFileUpload = async (e: Event) => {
    const target = e.target as HTMLInputElement;
    const file = target.files?.[0];
    if (!file) return;
    try {
      const data = await file.arrayBuffer();
      const workbook = read(data);
      const worksheet = workbook.Sheets[workbook.SheetNames[0]];
      const jsonData = utils.sheet_to_json(worksheet);
      const currentUser = authService.currentUser.value;
      const itemsToCreate = jsonData
        .map((row: any) => {
          const normalizedRow: any = {};
          Object.keys(row).forEach(key => {
            normalizedRow[key.trim().toLowerCase()] = row[key];
          });
          if (!normalizedRow.title || typeof normalizedRow.title !== 'string' || normalizedRow.title.trim() === '') {
            return null;
          }
          const tagsArray = (normalizedRow.tags || '')
            .split(',')
            .map((t: string) => t.trim())
            .filter(Boolean);
          return Item.create(
            Id.create(uuidv4()),
            Title.create(normalizedRow.title),
            Description.create(normalizedRow.description || ''),
            Author.create(normalizedRow.author || 'Unknown'),
            Cover.create(getRandomCover()),
            Owner.create(currentUser ? currentUser.name : ''),
            Tags.create(tagsArray),
            Topic.create(normalizedRow.topic || ''),
            Format.create(normalizedRow.format || ''),
            Created.create(normalizedRow.created ? new Date(normalizedRow.created) : new Date()),
            Completed.create(!!normalizedRow.completed), // boolean check
            Year.create(parseInt(normalizedRow.year) || new Date().getFullYear()),
            Publisher.create(normalizedRow.publisher || ''),
            Language.create(normalizedRow.language || 'English'),
            Category.create(Id.create(uuidv4()), Title.create(normalizedRow.category || 'books')),
            currentUser ? currentUser.id : Id.empty()
          );
        })
        .filter((item): item is Item => item !== null);
      if (itemsToCreate.length === 0) {
        notificationService.error(
          'No valid items found in file. Please ensure columns are correct and "Title" is present.'
        );
        return;
      }
      await itemStateService.createItems(itemsToCreate);
      route('/');
    } catch (error) {
      notificationService.error('Failed to parse file or create items');
      console.error(error);
    }
  };
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
      const currentUser = authService.currentUser.value;
      await itemStateService.createItem(
        Item.create(
          Id.create(uuidv4()),
          Title.create(formData.title),
          Description.create(formData.description),
          Author.create(formData.author),
          Cover.create(formData.cover),
          Owner.create(currentUser ? currentUser.name : ''),
          Tags.create(tagsArray),
          Topic.create(formData.topic),
          Format.create(formData.format),
          Created.create(new Date(formData.created)),
          Completed.create(formData.completed), // now a boolean
          Year.create(parseInt(formData.year) || 0),
          Publisher.create(formData.publisher),
          Language.create(formData.language),
          Category.create(Id.create(uuidv4()), Title.create(formData.category)),
          currentUser ? currentUser.id : Id.empty()
        )
      );
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
              class="w-full bg-zinc-900 border border-white/10 rounded p-3 text-white focus:border-brand-magenta focus:outline-none transition-colors scheme-dark"
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
        <div class="space-y-2 flex items-center gap-3 pt-6">
          <input
            type="checkbox"
            id="completed"
            checked={!!formData.completed}
            onChange={(e: any) => {
              setFormData(prev => ({
                ...prev,
                completed: e.target.checked
              }));
            }}
            class="w-5 h-5 bg-zinc-900 border border-white/10 rounded focus:ring-brand-magenta text-brand-magenta transition-colors cursor-pointer"
          />
          <label
            htmlFor="completed"
            class="text-xs font-bold uppercase tracking-widest text-brand-magenta cursor-pointer select-none"
          >
            Mark as Completed
          </label>
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
      <div class="relative py-4">
        <div class="absolute inset-0 flex items-center">
          <div class="w-full border-t border-white/10"></div>
        </div>
        <div class="relative flex justify-center text-xs uppercase tracking-widest">
          <span class="bg-black px-4 text-white/40">Or Import from Excel</span>
        </div>
      </div>
      <div class="space-y-4">
        <div class="p-6 border-2 border-dashed border-white/10 rounded-lg hover:border-brand-magenta/50 transition-colors text-center group cursor-pointer relative">
          <input
            type="file"
            accept=".xlsx, .xls, .ods"
            onChange={handleFileUpload}
            class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
          />
          <div class="space-y-2">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="w-10 h-10 mx-auto text-white/40 group-hover:text-brand-magenta transition-colors"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
              <polyline points="17 8 12 3 7 8" />
              <line x1="12" y1="3" x2="12" y2="15" />
            </svg>
            <p class="text-sm font-bold text-white/60 group-hover:text-white transition-colors">
              Click to upload or drag and drop
            </p>
            <p class="text-xs text-white/30">Supported files: .xlsx, .xls, .ods</p>
          </div>
        </div>
        <div class="text-xs text-white/30 space-y-1">
          <p class="font-bold">Expected columns:</p>
          <p>
            Title, Description, Author, Tags, Topic, Format, Created, Completed, Year, Publisher, Language, Category
          </p>
        </div>
      </div>
    </div>
  );
}
