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
  Language,
  Reference
} from '../../domain/model/value-objects/stringValues.valueObject';
import { Tags } from '../../domain/model/value-objects/tags.valueObject';
import { Created, Completed, Year } from '../../domain/model/value-objects/dateAndNumberValues.valueObject';
import { ItemsRepository } from '../../domain/repositories/items.repository';
import { injectable } from 'inversify';
import { db, auth } from '../firebase/firebaseConfig';
import { collection, doc, getDoc, getDocs, setDoc, deleteDoc, Timestamp, query, where, type DocumentData } from 'firebase/firestore';

@injectable()
export class FirebaseItemsRepository implements ItemsRepository {
  private readonly collectionName = 'items';

  constructor() {}

  async save(item: Item): Promise<void> {
    const itemRef = doc(db, this.collectionName, item.id.value);

    const data = {
      title: item.title.value,
      description: item.description.value,
      author: item.author.value,
      cover: item.cover.value,
      owner: item.owner.value,
      tags: item.tags.value,
      topic: item.topic.value,
      format: item.format.value,
      created: item.created.value,
      completed: item.completed.value,
      year: item.year.value,
      publisher: item.publisher.value,
      language: item.language.value,
      category: {
        id: item.category.id.value,
        name: item.category.name.value
      },
      reference: item.reference.value
    };

    await setDoc(itemRef, data);
  }

  async saveAll(items: Item[]): Promise<void> {
    await Promise.all(items.map(item => this.save(item)));
  }

  async findAll(ownerId?: string): Promise<Item[]> {
    const currentUser = auth.currentUser;
    const targetOwnerId = ownerId || currentUser?.uid;

    if (!targetOwnerId) {
      console.warn('[FirebaseItemsRepository] No owner ID provided for findAll and no current user');
      return [];
    }

    const q = query(collection(db, this.collectionName), where('owner', '==', targetOwnerId));

    const querySnapshot = await getDocs(q);
    return querySnapshot.docs.map(doc => this.mapToItem(doc.id, doc.data()));
  }

  async findById(id: Id): Promise<Item | undefined> {
    const docRef = doc(db, this.collectionName, id.value);
    const docSnap = await getDoc(docRef);

    if (docSnap.exists()) {
      return this.mapToItem(docSnap.id, docSnap.data());
    }
    return undefined;
  }

  async delete(id: Id): Promise<void> {
    const docRef = doc(db, this.collectionName, id.value);
    await deleteDoc(docRef);
  }

  async search(query: string): Promise<Item[]> {
    const allItems = await this.findAll();
    const lowerQuery = query.toLowerCase();

    return allItems.filter(
      item =>
        item.title.value.toLowerCase().includes(lowerQuery) ||
        item.author.value.toLowerCase().includes(lowerQuery) ||
        item.description.value.toLowerCase().includes(lowerQuery) ||
        item.publisher.value.toLowerCase().includes(lowerQuery) ||
        item.owner.value.toLowerCase().includes(lowerQuery) ||
        item.topic.value.toLowerCase().includes(lowerQuery) ||
        item.format.value.toLowerCase().includes(lowerQuery) ||
        item.language.value.toLowerCase().includes(lowerQuery) ||
        item.tags.value.some(tag => tag.toLowerCase().includes(lowerQuery)) ||
        item.category.name.value.toLowerCase().includes(lowerQuery)
    );
  }

  private mapToItem(id: string, docData: DocumentData): Item {
    const data = docData as {
      title: string;
      description: string;
      author: string;
      cover: string;
      owner: string;
      tags: string[];
      topic: string;
      format: string;
      created: Timestamp | Date | string;
      completed: boolean;
      year: number;
      publisher: string;
      language: string;
      category: { id: string; name: string };
      reference: string;
    };
    const createdDate =
      data.created instanceof Timestamp
        ? data.created.toDate()
        : data.created instanceof Date
          ? data.created
          : new Date(data.created);
    const completed = !!data.completed;

    return Item.create({
      id: Id.create(id),
      title: Title.create(data.title),
      description: Description.create(data.description),
      author: Author.create(data.author),
      cover: Cover.create(data.cover),
      owner: Owner.create(data.owner),
      tags: Tags.create(data.tags || []),
      topic: Topic.create(data.topic),
      format: Format.create(data.format),
      created: Created.create(createdDate),
      completed: Completed.create(completed),
      year: Year.create(data.year),
      publisher: Publisher.create(data.publisher),
      language: Language.create(data.language),
      category: Category.create(Id.create(data.category?.id || ''), Title.create(data.category?.name || '')),
      reference: Reference.create(data.reference ? data.reference.toString() : '0')
    });
  }
}
