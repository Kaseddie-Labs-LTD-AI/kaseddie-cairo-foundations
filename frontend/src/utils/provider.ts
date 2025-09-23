import React, { ReactNode } from 'react';

export const AppProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  return <div>{children}</div>;
};