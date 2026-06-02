/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Models;

import java.util.ArrayList;

/**
 *
 * @author ADMIN
 */
public interface IDAO<T, K> {
    
    public void add(T t);
    
    public void update(T t);
    
    public void remove(T t); //Just use Update not use Delete
    
    public ArrayList<T> ListAll();
    
    public ArrayList<T> searchByRoom(K id);
    
}
