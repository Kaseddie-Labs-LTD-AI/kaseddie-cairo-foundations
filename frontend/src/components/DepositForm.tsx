// src/components/DepositForm.tsx
import React, { useState } from 'react';
import { useStarknet } from 'starknet-react';
import { useUserVault } from '../hooks/useUserVault';

export function DepositForm({ onDone }: { onDone: () => void }) {
  const { account } = useStarknet();
  const vault = useUserVault();
  const [amount, setAmount] = useState('');
  const [error, setError] = useState<string>();
  const [loading, setLoading] = useState(false);

  const handleDeposit = async () => {
    setError(undefined);
    setLoading(true);
    try {
      if (+amount <= 0) throw new Error('Amount must be > 0');
      const tx = await vault.invoke('deposit', [BigInt(amount)], { from: account! });
      await tx.wait();
      onDone();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <section>
      <input
        type="number"
        placeholder="Amount"
        value={amount}
        onChange={e => setAmount(e.target.value)}
      />
      <button disabled={loading} onClick={handleDeposit}>
        {loading ? 'Depositing…' : 'Deposit'}
      </button>
      {error && <p className="error">{error}</p>}
    </section>
  );
}
