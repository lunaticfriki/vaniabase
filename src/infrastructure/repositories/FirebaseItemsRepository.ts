import { Item } from "../../domain/model/entities/Item";
import { Category } from "../../domain/model/entities/Category";
import { Id } from "../../domain/model/value-objects/Id";
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
} from "../../domain/model/value-objects/StringValues";
import { Tags } from "../../domain/model/value-objects/Tags";
import { Created, Completed, Year } from "../../domain/model/value-objects/DateAndNumberValues";
import { ItemsRepository } from "../../domain/repositories/ItemsRepository";
import { injectable } from "inversify";
import { db } from "../firebase/firebaseConfig";
import { collection, doc, getDoc, getDocs, setDoc, Timestamp } from "firebase/firestore";

@injectable()
export class FirebaseItemsRepository implements ItemsRepository {
    private readonly collectionName = "items";

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
            }
        };

        await setDoc(itemRef, data);
    }

    async findAll(): Promise<Item[]> {
        const querySnapshot = await getDocs(collection(db, this.collectionName));
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

    private mapToItem(id: string, data: any): Item {
        const createdDate = data.created instanceof Timestamp ? data.created.toDate() : (data.created instanceof Date ? data.created : new Date(data.created));
        const completedDate = data.completed ? (data.completed instanceof Timestamp ? data.completed.toDate() : (data.completed instanceof Date ? data.completed : new Date(data.completed))) : null;


        return Item.create(
            Id.create(id),
            Title.create(data.title),
            Description.create(data.description),
            Author.create(data.author),
            Cover.create(data.cover),
            Owner.create(data.owner),
            Tags.create(data.tags || []),
            Topic.create(data.topic),
            Format.create(data.format),
            Created.create(createdDate),
            Completed.create(completedDate),
            Year.create(data.year),
            Publisher.create(data.publisher),
            Language.create(data.language),
            Category.create(
                Id.create(data.category?.id || ''),
                Title.create(data.category?.name || '')
            )
        );
    }
}