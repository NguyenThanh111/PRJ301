/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Models_DAO;

import java.util.ArrayList;

/**
 *
 * @author ADMIN
 */
public interface IDAO<T, K> {
    
    public boolean insert(T t);
    
    public boolean update(T t);
    
    public boolean remove(T t); //Just use Update not use Delete
    
    public ArrayList<T> ListAll();
    
    public T searchById(K id);
    
}
