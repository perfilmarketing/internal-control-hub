import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import type { User, Session } from "@supabase/supabase-js";

export interface Profile {
  id: string;
  email: string;
  full_name: string | null;
  avatar_url: string | null;
  created_at: string;
  updated_at: string;
}

// Hook de autenticação desativado temporariamente
export function useAuth() {
  const [user] = useState<User | null>(null);
  const [session] = useState<Session | null>(null);
  const [profile] = useState<Profile | null>(null);
  const [loading] = useState(false);

  const signInWithGoogle = async () => {
    console.log("Autenticação desativada temporariamente");
  };

  const signOut = async () => {
    console.log("Autenticação desativada temporariamente");
  };

  return {
    user,
    session,
    profile,
    loading,
    signInWithGoogle,
    signOut,
  };
}
