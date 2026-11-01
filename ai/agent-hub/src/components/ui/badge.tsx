import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';
const variants = cva('inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-medium', { variants: { variant: { default: 'border-transparent bg-primary text-primary-foreground', secondary: 'border-transparent bg-secondary text-secondary-foreground', destructive: 'border-transparent bg-destructive text-destructive-foreground', outline: 'text-foreground' } }, defaultVariants: { variant: 'default' } });
export function Badge({ className, variant, ...props }: React.HTMLAttributes<HTMLDivElement> & VariantProps<typeof variants>) { return <div className={cn(variants({ variant }), className)} {...props} />; }
