import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Link } from "wouter";
import { Home } from "lucide-react";

export function AdminPage() {
  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="container mx-auto px-4 max-w-4xl">
        <div className="mb-6 flex justify-between items-center">
          <h1 className="text-3xl font-bold text-gray-900">Admin Panel</h1>
          <Link href="/">
            <Button variant="outline">
              <Home className="w-4 h-4 mr-2" />
              Back to Game
            </Button>
          </Link>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Static Mode</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-gray-600">
              This app is running in static mode. Question editing is not available.
            </p>
            <p className="text-gray-600 dark:text-gray-400 mt-2">
              Questions are loaded from static JSON files in the /data directory.
            </p>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}