class Dog
    attr_accessor :name, :breed
    attr_reader :id
    def initialize(name:,breed:,id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs;
        SQL

        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? LIMIT 1;
        SQL
        row = DB[:conn].execute(sql,name).first
        Dog.new_from_db(row)
    end

    def save
        dog = Dog.find(self.id)

        if dog
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name,breed) VALUES (?,?);
            SQL
            DB[:conn].execute(sql,self.name,self.breed)
            @id = DB[:conn].last_insert_row_id
            self
        end
    end

    # def self.find_by_id(id)
    #     sql = <<-SQL
    #         SELECT * FROM dogs WHERE id = ?;
    #     SQL
    #     row = DB[:conn].execute(sql,id).first

    #     if row == nil
    #         nil
    #     else
    #         Dog.new_from_db(row)
    #     end
    # end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ? , breed = ? WHERE id = >
        SQL
        DB{:conn}.execute(sql,self.name,self.breed,self.id)
    end

    def self.create(name:,breed:)
        dog = Dog.new(name: name,breed: breed)
        dog.save
    end

    def self.all
        sql = <<-SQL
            SELECT * FROM dogs;
        SQL

        data = DB[:conn].execute(sql)
        data.map {|row| self.new_from_db(row)}
    end

    def self.find(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?;
        SQL
        row = DB[:conn].execute(sql,id).first

        if row == nil
            nil
        else
            Dog.new_from_db(row)
        end
    end

    def self.find_or_create_by(name:,breed:)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?;
        SQL
        dog = DB[:conn].execute(sql,name,breed)

        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(id: dog_data[0],name: dog_data[1],breed: dog_data[2])
        else
            dog = self.create(name: name,breed: breed)
        end

        dog
    end
end
