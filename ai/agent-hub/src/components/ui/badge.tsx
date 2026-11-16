import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';
const variants = cva('badge', { variants: { variant: { default: 'badge-accent', secondary: '', destructive: 'badge-bad', outline: '' } }, defaultVariants: { variant: 'default' } });
export function Badge({ className, variant, ...props }: React.HTMLAttributes<HTMLDivElement> & VariantProps<typeof variants>) { return <div className={cn(variants({ variant }), className)} {...props} />; }
