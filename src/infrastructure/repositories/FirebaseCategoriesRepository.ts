import { Category } from "../../domain/model/entities/Category";
import { Id } from "../../domain/model/value-objects/Id";
import { Title } from "../../domain/model/value-objects/StringValues";
import { CategoriesRepository } from "../../domain/repositories/CategoriesRepository";
import { injectable } from "inversify";
import { db } from "../firebase/firebaseConfig";
import { collection, doc, getDoc, getDocs, setDoc } from "firebase/firestore";

@injectable()
export class FirebaseCategoriesRepository implements CategoriesRepository {
    private readonly collectionName = "categories";

    constructor() {}

    async save(category: Category): Promise<void> {
        const categoryRef = doc(db, this.collectionName, category.id.value);
        await setDoc(categoryRef, {
            name: category.name.value
        });
    }

    async findAll(): Promise<Category[]> {
        const querySnapshot = await getDocs(collection(db, this.collectionName));
        return querySnapshot.docs.map(doc => {
            const data = doc.data();
            return Category.create(
                Id.create(doc.id),
                Title.create(data.name)
            );
        });
    }

    async findById(id: Id): Promise<Category | undefined> {
        const docRef = doc(db, this.collectionName, id.value);
        const docSnap = await getDoc(docRef);

        if (docSnap.exists()) {
            const data = docSnap.data();
            return Category.create(
                Id.create(docSnap.id),
                Title.create(data.name)
            );
        }
        return undefined;
    }
}