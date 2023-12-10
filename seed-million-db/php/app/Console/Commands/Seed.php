<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Str;
use Illuminate\Process\Pool;
use Illuminate\Support\Facades\Process;

class Seed extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:seed {--processes=0}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Execute the console command.
     */
    // public function handle()
    // {
        
    //     $processes = (int) $this->option('processes');

    //     if($processes) {
    //         echo 'spawn';
    //         return $this->spawn($processes);
    //     }

    //     for($i = 0 ; $i < 10_000; $i++) {
    //         if($i % 100 == 0) {
    //             echo ".";
    //         }
    //         try{
                
    //             $this->insert();
    //         } catch (\Throwable $e) {
    //             // 
    //         }
    //     }
    // }

    public function handle()
    {
        
      
        for($i = 0 ; $i < 10_000; $i++) {
            if($i % 100 == 0) {
                echo ".";
            }
                $this->insert();
          
        }
    }

    /**
     * 
     */
    public function spawn($processes) {
        Process::pool(function(Pool $pool) use ($processes) {
            

            for( $i = 0; $i< $processes; ++$i) {
                $pool->command('php artisan app:seed')->timeout(60*5);

            }
        })->start()->wait();
    }
    /**
     * Method to insert through faker
     */
    public function insert()
    {
        echo 'insert....';

        User::create(
        [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'email_verified_at' => now()->subHours(rand(0,9999))->subMinutes(rand(0,9999)),
            'created_at' => now()->subHours(rand(0,9999))->subMinutes(rand(0,9999)),
            'password' => 'password',
            'remember_token' => Str::random(10),
        ]);
    }
}
