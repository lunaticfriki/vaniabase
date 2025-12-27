import type { Category } from "../../domain/model/entities/Category";
import type { Id } from "../../domain/model/value-objects/Id";
import type { CategoriesRepository } from "../../domain/repositories/CategoriesRepository";
import { injectable } from "inversify";

@injectable()
export class FirebaseCategoriesRepository implements CategoriesRepository {
    constructor() {
        console.log("FirebaseCategoriesRepository initialized");
    }

    async save(category: Category): Promise<void> {
        throw new Error("Method not implemented.");
    }
    async findAll(): Promise<Category[]> {
        throw new Error("Method not implemented.");
    }
    async findById(id: Id): Promise<Category | undefined> {
        throw new Error("Method not implemented.");
    }
}