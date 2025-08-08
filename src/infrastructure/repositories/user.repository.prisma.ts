import { prisma } from '../db/prisma-client';
import { IUserRepository } from '../../interfaces/repositories/user.repository.port';
import { User } from '../../domain/user/user.entity';

export class PrismaUserRepository implements IUserRepository {
  async findByEmail(email: string) {
    const rec = await prisma.user.findUnique({ where: { email } });
    return rec ? User.create(rec as any) : null;
  }
  async findById(id: string) {
    const rec = await prisma.user.findUnique({ where: { id } });
    return rec ? User.create(rec as any) : null;
  }
  async create(user: User) {
    const created = await prisma.user.create({ data: { email: user.email, passwordHash: user.passwordHash, displayName: user.displayName } });
    return User.create(created as any);
  }
}
