import { TokenPair } from '../../../domain/auth/tokens';
export interface ITokenService {
  issuePair(userId: string, email: string): Promise<TokenPair>;
  verifyAccess(token: string): Promise<{ userId: string; email: string } | null>;
}
