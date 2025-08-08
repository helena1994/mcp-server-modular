import { RegisterUserDTO } from '../../dto/user.dto';
import { IUserRepository } from '../../../interfaces/repositories/user.repository.port';
import { IHashingService } from '../../services/hashing/hashing.port';
import { User } from '../../../domain/user/user.entity';
import { ValidationError } from '../../../domain/shared/errors';

export class RegisterUserUseCase {
  constructor(private repo: IUserRepository, private hashing: IHashingService) {}

  async execute(dto: RegisterUserDTO) {
    const existing = await this.repo.findByEmail(dto.email);
    if (existing) throw new ValidationError('Email already registered');
    const passwordHash = await this.hashing.hash(dto.password);
    const user = User.create({ id: '', email: dto.email, passwordHash, displayName: dto.displayName });
    const saved = await this.repo.create(user);
    return { id: saved.id, email: saved.email, displayName: saved.displayName };
  }
}
