import { ReactNode } from "react";

interface ProtectedRouteProps {
  children: ReactNode;
}

// Autenticação desativada temporariamente
export function ProtectedRoute({ children }: ProtectedRouteProps) {
  return <>{children}</>;
}

