import type { Item } from "../../domain/model/entities/Item";
import type { Id } from "../../domain/model/value-objects/Id";
import type { ItemsRepository } from "../../domain/repositories/ItemsRepository";
import { injectable } from "inversify";

@injectable()
export class FirebaseItemsRepository implements ItemsRepository {
    constructor() {
        console.log("FirebaseItemsRepository initialized");
    }

    async save(item: Item): Promise<void> {
        throw new Error("Method not implemented.");
    }
    async findAll(): Promise<Item[]> {
        throw new Error("Method not implemented.");
    }
    async findById(id: Id): Promise<Item | undefined> {
        throw new Error("Method not implemented.");
    }
}