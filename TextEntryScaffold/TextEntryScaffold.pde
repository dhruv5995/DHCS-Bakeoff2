import java.util.Arrays;
import java.util.Collections;
import java.util.Queue;
import java.util.LinkedList;
import java.util.ArrayList;

String[] phrases;
String[] dictionary;
int totalTrialNum = 4; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
String currentWord = "";
int characters = 0;
int lastSpace = 0;
ArrayList <String> currentMatches;
int currentMatchLoc = 0;
boolean clickedSpace = false;
final int DPIofYourDeviceScreen = 326; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
                                      //http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1.25; //aka, 1.25 inches square!
Trie t;

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases
  orientation(PORTRAIT); //can also be LANDSCAPE -- sets orientation on android device
  size(1000, 500); //Sets the size of the app. You may want to modify this to your device. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 36)); //set the font to arial 36
  noStroke(); //my code doesn't use any strokes.
  
  t = new Trie();
  dictionary = loadStrings("dictionary.txt"); //load the dictionary set into memory
  for(int i = 0; i < dictionary.length; i++)
  {
    t.insert(dictionary[i]); 
  }
  
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(0); //clear background

  fill(100);
  rect(200, 200, sizeOfInputArea, sizeOfInputArea); //input area should be 2" by 2"
  

  if (finishTime!=0)
  {
    fill(255);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(255);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //you will need something like the next 10 lines in your code. Output does not have to be within the 2 inch area!
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(255);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped, 70, 140); //draw what the user has entered thus far 
    fill(255, 0, 0);
    rect(800, 00, 200, 200); //drag next button
    fill(255);
    text("NEXT > ", 850, 100); //draw next label


    //draw the grid
    stroke(255,255,255);
    line(200, 200+sizeOfInputArea/3, 200+sizeOfInputArea, 200+sizeOfInputArea/3);
    line(200, 200+2*sizeOfInputArea/3, 200+sizeOfInputArea, 200+2*sizeOfInputArea/3);
    
    line(200+sizeOfInputArea/3, 200, 200+sizeOfInputArea/3, 200+sizeOfInputArea);
    line(200+2*sizeOfInputArea/3, 200, 200+2*sizeOfInputArea/3, 200+sizeOfInputArea);
    
    //add text to the grid
    fill(255,255,255);
    textAlign(CENTER, CENTER);
    text("Space\nBack", 200+sizeOfInputArea/6, 200+sizeOfInputArea/6);
    text("A,B,C", 200+3*sizeOfInputArea/6, 200+sizeOfInputArea/6);
    text("D,E,F", 200+5*sizeOfInputArea/6, 200+sizeOfInputArea/6);
    
    text("G,H,I", 200+sizeOfInputArea/6, 200+3*sizeOfInputArea/6);
    text("J,K,L", 200+3*sizeOfInputArea/6, 200+3*sizeOfInputArea/6);
    text("M,N,O", 200+5*sizeOfInputArea/6, 200+3*sizeOfInputArea/6);
    
    text("P,Q,R,S", 200+sizeOfInputArea/6, 200+5*sizeOfInputArea/6);
    text("T,U,V", 200+3*sizeOfInputArea/6, 200+5*sizeOfInputArea/6);
    text("W,X,Y,Z", 200+5*sizeOfInputArea/6, 200+5*sizeOfInputArea/6);
    
    stroke(0);
  }
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}


void mousePressed()
{
  if(startTime > 0)
  {
    boolean addLetter = false;
    //Check if in upper left
    if (didMouseClick(200, 200, sizeOfInputArea/3, sizeOfInputArea/3)) //check if click is in next button
    {
      clickedSpace = true;
    }
    
    //Check if in upper middle
    else if (didMouseClick(200+sizeOfInputArea/3, 200, sizeOfInputArea/3, sizeOfInputArea/3)) //check if click is in next button
    {
      clickedSpace = false;
      currentWord += '2';
      characters++;
      addLetter = true;
    }
    
    //Check if in upper right
    else if (didMouseClick(200+2*sizeOfInputArea/3, 200, sizeOfInputArea/3, sizeOfInputArea/3)) //check if click is in next button
    {
      clickedSpace = false;
      currentWord += '3';
      characters++;
      addLetter = true;
    }
    
    //Check if in middle left
    else if (didMouseClick(200, 200+sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea/3)) //check if click is in next button
    {
      clickedSpace = false;
      currentWord += '4';
      characters++;
      addLetter = true;
    }
    
    //Check if in middle middle
    else if (didMouseClick(200+sizeOfInputArea/3, 200+sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea/3)) //check if click is in next button
    {
      clickedSpace = false;
      currentWord += '5';
      characters++;
      addLetter = true;
    }
    
    //Check if in middle right
    else if (didMouseClick(200+2*sizeOfInputArea/3, 200+sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea/3)) //check if click is in next button
    {
      clickedSpace = false;
      currentWord += '6';
      characters++;
      addLetter = true;
    }
    
    //Check if in lower left
    else if (didMouseClick(200, 200+2*sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea/3)) //check if click is in next button
    {
      clickedSpace = false;
      currentWord += '7';
      characters++;
      addLetter = true;
    }
    
    //Check if in lower middle
    else if (didMouseClick(200+sizeOfInputArea/3, 200+2*sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea/3)) //check if click is in next button
    {
      clickedSpace = false;
      currentWord += '8';
      characters++;
      addLetter = true;
    }
    
    //Check if in lower right
    else if (didMouseClick(200+2*sizeOfInputArea/3, 200+2*sizeOfInputArea/3, 200+sizeOfInputArea, 200+sizeOfInputArea)) //check if click is in next button
    {
      clickedSpace = false;
      currentWord += '9';
      characters++;
      addLetter = true;
    }
    
    
    //Predict the word
    if(addLetter)
    {
      System.out.println(lastSpace);
      if(lastSpace > 0)
      {
        currentTyped = currentTyped.substring(0, lastSpace);
      }
      else
      {
        currentTyped = "";
      }
      currentMatches = checkWord(currentWord);
      currentMatchLoc = 0;
      currentTyped += currentMatches.get(0);
    }
  }
  
  //You are allowed to have a next button outside the 2" area
  if (didMouseClick(800, 00, 200, 200)) //check if click is in next button
  {
    clickedSpace = false;
    nextTrial(); //if so, advance to next trial
  }
}

void mouseReleased()
{
  if (didMouseClick(200, 200, sizeOfInputArea/3, sizeOfInputArea/3) && clickedSpace) //check if click is in next button
  {
    if(lastSpace == characters)
    {
      characters -= 2;
      if(characters > 0)
      {
        boolean foundSpace = false;
        for(int j = characters; j >= 0; j--)
        {
          if(currentTyped.charAt(j) == ' ')
          {
            lastSpace = j;
            foundSpace = true;
            break; 
          }
        }
        if(!foundSpace)
        {
          lastSpace = 0;
        }
        currentTyped = currentTyped.substring(0,characters);
        currentWord = currentTyped.substring(lastSpace,characters);
        currentWord = convertLetterstoNumbers(currentWord);
        System.out.println("currentTyped ******"+currentTyped+"******"+"  currentWord *******"+currentWord+"******");
      }
      else
      {
        characters = 0;
        currentTyped = "";
        currentWord = "";
        lastSpace = 0;
      }
    }
    else
    {
      currentWord = "";
      currentTyped += ' ';
      characters++;
      lastSpace = characters;
    }
    clickedSpace = false;
  }
  else if(!didMouseClick(200, 200, sizeOfInputArea/3, sizeOfInputArea/3) && clickedSpace)
  {
    if(lastSpace > 0)
    {
      currentTyped = currentTyped.substring(0, lastSpace);
    }
    else
    {
      currentTyped = "";
    }
    currentMatchLoc++;
    if(currentMatchLoc >= currentMatches.size())
    {
      currentMatchLoc = 0;
    }
    currentTyped += currentMatches.get(currentMatchLoc);
    
  }
}

//This function will predict the word
ArrayList <String> checkWord(String currentWord)
{
  currentWord = currentWord.trim();
  ArrayList <String> word = t.bfs_search(currentWord);
  if(word != null && word.size() > 0)
  {
    return word;
  }
  else
  {
    for(int i = currentWord.length(); i >=0 ; i--)
    {
      word = t.bfs_search(currentWord.substring(0,i));
      if(word != null && word.size() > 0)
      {
        System.out.println(word.get(0));
        for(int j = i; j < currentWord.length(); j++)
        {
          for(int k = 0; k < word.size(); k++)
          {
            word.set(k, word.get(k)+ getCharbyNum(currentWord.charAt(currentWord.length()-j-1)));
          }
        }
        return word;
      }
    }
    
    word.add("");
    for(int j = 0; j < currentWord.length(); j++)
    {
      word.set(0, word.get(0) + getCharbyNum(currentWord.charAt(currentWord.length()-j-1)));
    }
    return word;
  }
}

String convertLetterstoNumbers(String word)
{
  String val = "";
  System.out.println(word);
  for(int i = 0; i < word.length(); i++)
  {
    System.out.println(word.charAt(i)+"    "+convertCharacterToNum(word.charAt(i)));
    val += convertCharacterToNum(word.charAt(i));
  }
  return val; 
}

char convertCharacterToNum(char letter)
{
  switch(letter)
  {
    case 'a':
    case 'b':
    case 'c':
      return '2';
    case 'd':
    case 'e':
    case 'f':
      return '3';
    case 'g':
    case 'h':
    case 'i':
      return '4';
    case 'j':
    case 'k':
    case 'l':
      return '5';
    case 'm':
    case 'n':
    case 'o':
      return '6';
    case 'p':
    case 'q':
    case 'r':
    case 's':
      return '7';
    case 't':
    case 'u':
    case 'v':
      return '8';
    case 'w':
    case 'x':
    case 'y':
    case 'z':
      return '9';
  }
  return ' ';
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

    if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.length();
    lettersEnteredTotal+=currentTyped.length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output
    System.out.println("WPM: " + (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f)); //output
    System.out.println("==================");
    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  }
  else
  {
    currTrialNum++; //increment trial number
  }

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentWord = "";
  characters = 0;
  lastSpace = 0;
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


char getCharbyNum(char num)
{
  switch(num)
  {
    case '2':
      return 'a';
    case '3':
      return 'd';
    case '4':
      return 'g';
    case '5':
      return 'j';
    case '6':
      return 'm';
    case '7':
      return 'p';
    case '8':
      return 't';
    case '9':
      return 'w';
  }
  return ' ';
}



//=========SHOULD NOT NEED TO TOUCH THIS AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2)  
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}










public class Trie {
  
  private final int R = 26;  // the trie branches 
  private Node root = new Node(); // the root node
  
  // the t9 mapped array which maps number to string on the typing board
  private String[] t9 = {"", "", "abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz"};
  
  // trie node definition
  private class Node {
    private boolean isWord;
    private Node[] next;
    
    public Node() {
      this(false);
    }
    
    public Node(boolean isWord) {
      this.isWord = isWord;
      this.next = new Node[R];
    }
  }
  
  // insert a word to the trie
  public void insert(String s) {
    Node current = root;
    
    for(int i = 0; i < s.length(); i++) {
      if(current.next[s.charAt(i) - 'a'] == null) {
        Node n = new Node();
        current.next[s.charAt(i) - 'a'] = n;
      } 
      
      current = current.next[s.charAt(i) - 'a'];
    }
    
    current.isWord = true;
  }
  
  // insert a character to some node
  public void insert(Node current, char c) {
    if(current.next[c - 'a'] == null) {
      Node node = new Node();
      current.next[c - 'a'] = node;
    }
    current = current.next[c - 'a'];
  }
  
  // search a word in the trie
  public boolean search(String s) {
    Node current = root;
    
    for(int i = 0; i < s.length(); i++) {
      if(current.next[s.charAt(i) - 'a'] == null) {
        return false;
      } 
      current = current.next[s.charAt(i) - 'a'];
    }
    
    return current.isWord == true;
  }
  
  // breadth first search for a number string use queue
  public ArrayList <String> bfs_search(String strNum) {
    Queue<String> q = new LinkedList<String>();
    ArrayList <String> matches = new ArrayList <String> ();
    
    q.add("");
    
    for(int i = 0; i < strNum.length(); i++) {
      String keyStr = t9[strNum.charAt(i) - '0'];
      int len = q.size();
      
      while(len -- > 0) {
        String preStr = q.remove();
        for(int j = 0; j < keyStr.length(); j++) {
          String tmpStr = preStr + keyStr.charAt(j);
          //q.add(tmpStr);
          if(search(tmpStr) && tmpStr.length() == strNum.length()) {
            matches.add(tmpStr);
          } else {
            q.add(tmpStr);
          }
        }
      }
    }
    return matches;
  }
  
  // delete a node
  public void delete(Node node) {
    for(int i = 0; i < R; i++) {
      if(node.next != null) {
        delete(node.next[i]);
      }
    }
    node = null;
  }
  
  // print words
  public void print(Node node) {
    if(node == null) return;
    for(int i = 0; i < R; i++) {
      if(node.next[i] != null) {
        System.out.print((char) (97 + i));
        if(node.next[i].isWord == true) {
          System.out.println();
        }
        print(node.next[i]);
      }
      
    }
  }
  
  // print words from root
  public void print() {
    print(root);
  }
  
  // convert number string to String array
  private String[] numToString(String strNum) {
    String[] strArray = new String[strNum.length()];
    for(int i = 0; i < strNum.length(); i++) {
      strArray[i] = t9[strNum.charAt(i) - '0'];
    }
    return strArray;
  }
}
