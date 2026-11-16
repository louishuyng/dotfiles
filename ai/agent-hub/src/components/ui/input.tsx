import * as React from 'react';
import { cn } from '@/lib/utils';
const Input = React.forwardRef<HTMLInputElement, React.ComponentProps<'input'>>(({ className, type, ...props }, ref) => <input type={type} className={cn('input', className)} ref={ref} {...props} />);
Input.displayName = 'Input';
export { Input };
