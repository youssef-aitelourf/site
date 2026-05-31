import type { NextConfig } from "next";

const PORTFOLIO_URL = "https://portfolio-2-youssef-ait-elourfs-projects.vercel.app";
const NUTRITION_URL =
  process.env.NUTRITION_URL ??
  "https://nutrition-youssef-ait-elourfs-projects.vercel.app";

const nextConfig: NextConfig = {
  env: {
    NEXT_PUBLIC_SUPABASE_URL: process.env.SUPABASE_URL,
    NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY,
  },
  async redirects() {
    return [
      { source: "/", destination: "/portfolio", permanent: true },
      // CV Adapter désactivé
      { source: "/cv-adapter", destination: "/portfolio", permanent: false },
      { source: "/cv-adapter/:path*", destination: "/portfolio", permanent: false },
      { source: "/admin/cv-adapter", destination: "/admin", permanent: false },
      { source: "/admin/cv-adapter/:path*", destination: "/admin", permanent: false },
      // health-app remplacé par nutrition
      { source: "/admin/health-app", destination: "/nutrition", permanent: false },
      { source: "/admin/health-app/:path*", destination: "/nutrition", permanent: false },
    ];
  },
  async rewrites() {
    return [
      { source: "/portfolio", destination: `${PORTFOLIO_URL}/portfolio` },
      { source: "/portfolio/:path*", destination: `${PORTFOLIO_URL}/portfolio/:path*` },
      { source: "/nutrition", destination: `${NUTRITION_URL}/nutrition` },
      { source: "/nutrition/:path*", destination: `${NUTRITION_URL}/nutrition/:path*` },
    ];
  },
};

export default nextConfig;
