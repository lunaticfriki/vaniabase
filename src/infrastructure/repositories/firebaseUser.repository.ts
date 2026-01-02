import { injectable } from 'inversify';
import { db } from '../firebase/firebaseConfig';
import { doc, setDoc, getDoc } from 'firebase/firestore';
import { UserRepository } from '../../domain/repositories/user.repository';
import { User } from '../../domain/model/entities/user.entity';
import { Id } from '../../domain/model/value-objects/id.valueObject';

@injectable()
export class FirebaseUserRepository implements UserRepository {
  private readonly collectionName = 'users';

  async save(user: User): Promise<void> {
    const userRef = doc(db, this.collectionName, user.id.value);
    const data = {
      id: user.id.value,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      createdAt: new Date()
    };
    await setDoc(userRef, data, { merge: true });
  }

  async findById(id: Id): Promise<User | undefined> {
    const userRef = doc(db, this.collectionName, id.value);
    const docSnap = await getDoc(userRef);

    if (docSnap.exists()) {
      const data = docSnap.data();
      return User.create(
        Id.create(data.id as string),
        data.name as string,
        data.email as string,
        data.avatar as string
      );
    }
    return undefined;
  }
}
