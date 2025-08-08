import { LoginUserDTO } from '../../dto/user.dto';
import { IUserRepository } from '../../../interfaces/repositories/user.repository.port';
import { IHashingService } from '../../services/hashing/hashing.port';
import { ITokenService } from '../../services/token/token.port';
import { AuthError } from '../../../domain/shared/errors';

export class LoginUserUseCase {
  constructor(
    private repo: IUserRepository,
    private hashing: IHashingService,
    private tokens: ITokenService,
  ) {}

  async execute(dto: LoginUserDTO) {
    const user = await this.repo.findByEmail(dto.email);
    if (!user) throw new AuthError('Invalid credentials');
    const ok = await this.hashing.verify(user.passwordHash, dto.password);
    if (!ok) throw new AuthError('Invalid credentials');
    const tokenPair = await this.tokens.issuePair(user.id, user.email);
    return { user: { id: user.id, email: user.email }, tokens: tokenPair };
  }
}
