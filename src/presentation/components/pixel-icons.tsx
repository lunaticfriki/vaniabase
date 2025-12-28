import type { JSX } from 'preact';

interface IconProps extends JSX.SVGAttributes<SVGSVGElement> {
  size?: number;
  className?: string;
}

const PixelIcon = ({ size = 24, className = '', children, ...props }: IconProps) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    width={size}
    height={size}
    className={className}
    shape-rendering="crispEdges"
    fill="currentColor"
    {...props}
  >
    {children}
  </svg>
);

export const HomeIcon = (props: IconProps) => (
  <PixelIcon {...props}>
    <path d="M10 2h4v2h-4V2zM6 6h4V4H6v2zm8 0h4v2h-4V6zM4 10h2V6H4v4zm14 0h2V6h-2v4zM2 14h2v-4H2v4zm18 0h2v-4h-2v4zM2 22h8v-8H6v4H4v4zm12 0h8v-8h-2v4h-2v4h-4z" />
    <path d="M10 22h4v-6h-4v6z" />
  </PixelIcon>
);

export const CollectionIcon = (props: IconProps) => (
  <PixelIcon {...props}>
    <path d="M4 4h4v2H4V4zm6 0h10v2H10V4zM4 8h4v2H4V8zm6 0h10v2H10V8zM4 12h4v2H4v-2zm6 0h10v2H10v-2zM4 16h4v2H4v-2zm6 0h10v2H10v-2zM4 20h4v2H4v-2zm6 0h10v2H10v-2z" />
  </PixelIcon>
);

export const CategoriesIcon = (props: IconProps) => (
  <PixelIcon {...props}>
    <path d="M2 4h8v2H2V4zm0 6h2V8H2v2zm4 0h16V8H6v2zM2 14h2v-2H2v2zm4 0h16v-2H6v2zM2 18h2v-2H2v2zm4 0h16v-2H6v2zM2 22h20v-2H2v2z" />
  </PixelIcon>
);

export const TagsIcon = (props: IconProps) => (
  <PixelIcon {...props}>
    <path d="M12 2h8v8h-2v2h-2v2h-2v2h-2v2h-2v-2H8v-2H6v-2H4V8H2V2h10zm2 6h2V4h-2v4z" />
  </PixelIcon>
);

export const TopicsIcon = (props: IconProps) => (
  <PixelIcon {...props}>
    <path d="M8 2h2v4h4V2h2v4h4v2h-4v4h4v2h-4v4h-2v-4h-4v4H8v-4H4v-2h4V8H4V6h4V2zm2 6v4h4V8h-4z" />
  </PixelIcon>
);

export const FormatsIcon = (props: IconProps) => (
  <PixelIcon {...props}>
    <path d="M4 2h10v2h2v2h2v2h2v14H4V2zm2 2v16h12V8h-2V6h-2V4H6z" />
  </PixelIcon>
);

export const SearchIcon = (props: IconProps) => (
  <PixelIcon {...props}>
    <path d="M10 4h4v2h-4V4zM6 8h2V6H6v2zm10 0h2V6h-2v2zm-2 2h-4v2h4v-2zm-6 0h2V8H8v2zm8 0h2V8h-2v2zm-2 4h-4v-2h4v2zm2 0h-2v-2h2v2zM6 14h2v-2H6v2zm10 0h2v-2h-2v2zm2 4v-2h-2v2h-2v2h2v2h2v-2h2v-2h-4z" />
    <path d="M8 12h2v2H8v-2z" />
  </PixelIcon>
);

export const CreateIcon = (props: IconProps) => (
  <PixelIcon {...props}>
    <path d="M22 4h-2v4h-4v2h4v4h2v-4h4V8h-4V4zM2 20h14v2H2v-2zm0-4h10v2H2v-2zm0-4h12v2H2v-2zm0-4h8v2H2V8zm0-4h6v2H2V4z" />
  </PixelIcon>
);

export const AboutIcon = (props: IconProps) => (
  <PixelIcon {...props}>
    <path d="M10 2h4v4h-4V2zm0 6h4v12h-4v-2h-2v-2h2V8zm-2 14h8v-2H8v2z" />
  </PixelIcon>
);

export const CompletedIcon = (props: IconProps) => (
  <PixelIcon {...props}>
    <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
  </PixelIcon>
);

export const LogoutIcon = (props: IconProps) => (
  <PixelIcon {...props}>
    <path d="M4 4h2v16H4V4zm4 0h8v2H8V4zm8 0h2v4h-2V4zm-2 6h4v2h-4v-2zm-2 8h-2v-2h2v2zm2 0h4v-2h-4v2zm4-4h2v4h-2v-4zm-4-4h2v2h-2v-2zm-2 0h-2v2h2V10z" />
    <path d="M12 14h2v2h-2v-2z" />
  </PixelIcon>
);
