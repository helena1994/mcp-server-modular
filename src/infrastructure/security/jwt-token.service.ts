import jwt from 'jsonwebtoken';
import { ITokenService } from '../../application/services/token/token.port';
import { env } from '../../app/config/env';

export class JwtTokenService implements ITokenService {
  async issuePair(userId: string, email: string) {
    const accessToken = jwt.sign({ sub: userId, email }, env.JWT_ACCESS_SECRET, { expiresIn: env.JWT_ACCESS_EXPIRES });
    const refreshToken = jwt.sign({ sub: userId, email, rt: true }, env.JWT_REFRESH_SECRET, { expiresIn: env.JWT_REFRESH_EXPIRES });
    return { accessToken, refreshToken };
  }
  async verifyAccess(token: string) {
    try {
      const payload = jwt.verify(token, env.JWT_ACCESS_SECRET) as any;
      return { userId: payload.sub, email: payload.email };
    } catch {
      return null;
    }
  }
}
