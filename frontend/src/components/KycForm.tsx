// src/components/KycForm.tsx
import React, { useState } from 'react';
import { useStarknet } from 'starknet-react';
import { useUserVault } from '../hooks/useUserVault';

export function KycForm() {
  const { account } = useStarknet();
  const vault = useUserVault();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string>();

  const handleVerify = async () => {
    setError(undefined);
    setLoading(true);
    try {
      const tx = await vault.invoke('verify_owner', [], { from: account! });
      await tx.wait();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <section>
      <button disabled={loading || !account} onClick={handleVerify}>
        {loading ? 'Verifying…' : 'Verify KYC'}
      </button>
      {error && <p className="error">{error}</p>}
    </section>
  );
}
