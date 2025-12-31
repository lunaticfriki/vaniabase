import { injectable } from 'inversify';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { storage } from '../firebase/firebaseConfig';
import { StorageService } from '../../application/services/storage.service';

@injectable()
export class FirebaseStorageService implements StorageService {
  async upload(file: File, path: string): Promise<string> {
    const storageRef = ref(storage, path);
    const snapshot = await uploadBytes(storageRef, file);
    return await getDownloadURL(snapshot.ref);
  }
}
